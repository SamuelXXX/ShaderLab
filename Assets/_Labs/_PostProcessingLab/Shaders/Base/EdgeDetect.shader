// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/PostProcess/EdgeDetect"
{
    Properties
    {
        _MainTex("Base (RGB)",2D)="white"{}
        _EdgeAmplifier("Edge Amplifier",Range(0,5))=1.0
        _EdgeOnly("Edge Only",Float)=1.0
        _EdgeColor("Edge Color",Color)=(0,0,0,1)
        _BackgroundColor("Background Color",Color)=(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags{"RenderType"="Opaque"}
            ZWrite Off
            ZTest Always
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 position:SV_POSITION;
                half2 uv[9]:TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            float _EdgeAmplifier;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

            fixed luminance(fixed4 color);
            half Sobel(v2f i);

            v2f vert(appdata_img v)
            {
                v2f o;
                o.position=UnityObjectToClipPos(v.vertex);

                half2 uv=v.texcoord;

                o.uv[0]=uv+_MainTex_TexelSize.xy*half2(-1,-1);
                o.uv[1]=uv+_MainTex_TexelSize.xy*half2(0,-1);
                o.uv[2]=uv+_MainTex_TexelSize.xy*half2(1,-1);
                o.uv[3]=uv+_MainTex_TexelSize.xy*half2(-1,0);
                o.uv[4]=uv+_MainTex_TexelSize.xy*half2(0,0);
                o.uv[5]=uv+_MainTex_TexelSize.xy*half2(1,0);
                o.uv[6]=uv+_MainTex_TexelSize.xy*half2(-1,1);
                o.uv[7]=uv+_MainTex_TexelSize.xy*half2(0,1);
                o.uv[8]=uv+_MainTex_TexelSize.xy*half2(1,1);

                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                half edge=Sobel(i);

                fixed4 withEdgeColor=lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]),edge);
                fixed4 onlyEdgeColor=lerp(_EdgeColor,_BackgroundColor,edge);
                return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
            }

            fixed luminance(fixed4 color)
            {
                return 0.2125*color.r+0.7154*color.g+0.0721*color.b;
            }

            half Sobel(v2f i)
            {
                const half Gx[9]={-1,-2,-1,
                                 0,0,0,
                                 1,2,1};
                const half Gy[9]={-1,0,1,
                                -2,0,2,
                                -1,0,1};

                half texColor;
                half edgeX=0;
                half edgeY=0;
                float depth;

                for(int it=0;it<9;it++){
                    texColor=luminance(tex2D(_CameraDepthTexture,i.uv[it]));
                    depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv[it]))*_EdgeAmplifier;
                    
                    //edgeX+=texColor*Gx[it];
                    //edgeY+=texColor*Gy[it];
                    edgeX+=depth*Gx[it];
                    edgeY+=depth*Gy[it];
                }

                return 1-abs(edgeX)-abs(edgeY);
            }
            ENDCG
        }
    }
    FallBack Off
}
