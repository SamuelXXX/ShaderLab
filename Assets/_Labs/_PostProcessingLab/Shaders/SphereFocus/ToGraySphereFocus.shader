Shader "ShaderLab/PostProcess/ToGraySphereFocus"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FocusCenter("Center",Vector)=(0,0,0,0)
        _FocusRange("Range",Float)=1
        _BorderWidth("BorderWidth",Range(0.01,1))=0.2
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        ZWrite Off ZTest Always Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float4 _FocusCenter;
            float _FocusRange;
            float _BorderWidth;

            float4x4 _InverseVPMatrix;

            fixed luminance(fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            float4 GetWorldPositionOfPixel(float2 uv)
            {
                float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv));
                #if defined(UNITY_REVERSED_Z)
                    depth = 1 - depth;
                #endif
                float4 H=float4(uv.x*2-1 ,uv.y*2-1,depth*2-1,1.0);
                
                float4 D=mul(_InverseVPMatrix,H);
                return D/D.w;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 pixelPosition=GetWorldPositionOfPixel(i.uv);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed r=luminance(col);
                
                float dist=distance(_FocusCenter,pixelPosition)/_FocusRange;
                dist=saturate(dist);

                float t=0;
                if(dist>=1-_BorderWidth)
                {
                    t=(dist+_BorderWidth-1)/_BorderWidth;
                }
                    

                return lerp(col,fixed4(r,r,r,1),t);
            }
            ENDCG
        }
    }
}
