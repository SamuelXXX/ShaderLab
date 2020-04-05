// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/UnlitTexture"
{
    Properties
    {
        _Texture("MainTexture",2D)="white"{}
    }

    SubShader
    {
        Tags{"Queue"="Geometry" "RenderType"="Opaque"}
        Pass{
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _Texture;
            struct appdata{
                float4 position:POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.position=UnityObjectToClipPos(v.position);
                o.uv=v.uv;

                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                return tex2D(_Texture,i.uv);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
