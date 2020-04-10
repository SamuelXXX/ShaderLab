// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/Rim/UnlitTextureWithRim"
{
    Properties
    {
        _MainTex("MainTexture",2D)="white"{}
        _RimColor("RimColor",Color) = (1.0,1.0,1.0,1.0)
		_RimFill("RimFill",Range(-1,1)) = 0
    }

    SubShader
    {
        Tags{"Queue"="Geometry" "RenderType"="Opaque"}
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            fixed4 _RimColor;
            fixed _RimFill;

            struct appdata{
                float4 position:POSITION;
                fixed3 normal:NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct v2f{
                float4 position:SV_POSITION;
                fixed3 viewNormal:POSITION1;
                float3 viewPosition:POSITION2;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.position=UnityObjectToClipPos(v.position);
                o.uv=v.uv;

                o.viewNormal=mul(UNITY_MATRIX_MV,v.normal);
                o.viewPosition=mul(UNITY_MATRIX_MV,v.position);

                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float t = 1 + dot(normalize(i.viewNormal), normalize(i.viewPosition)) + _RimFill;//Transparency Factor
				t = saturate(t)*_RimColor.a;
                
                return (1-t)*tex2D(_MainTex,i.uv)+t*fixed4(_RimColor.rgb,1);
            }
            ENDCG
        }
    }
}
