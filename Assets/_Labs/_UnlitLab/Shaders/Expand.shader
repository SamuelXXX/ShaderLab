// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/Expand"
{
    Properties
    {
        _Texture("Texture",2D)="white"{}
        _Expand("Expand",Range(-0.1,0.1)) = 0
    }

    SubShader
    {
        Tags{"Queue"="Geometry" "RenderType"="Opaque"}

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _Texture;
            float _Expand;

            struct appdata{
                float4 position:POSITION;
                float3 normal:NORMAL;
                float2 uv:TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.uv=v.uv;

                float3 expandPosition=v.position.xyz+normalize(v.normal)*_Expand;
                o.position=UnityObjectToClipPos(float4(expandPosition,1));
                return o;
            }

            float4 frag(v2f f):SV_TARGET
            {
                return tex2D(_Texture,f.uv);
            }
            ENDCG
        }
    }
}
