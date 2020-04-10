// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "ShaderLab/Unlit/Misc/MirrorReflection"
{
	Properties
	{
		_MainColor ("Base (RGB)", Color) = (1,1,1,1)
		_ReflectionTex ("", 2D) = "white" {}
	}
	SubShader
	{
		Tags {"Queue"="Transparent+1" "RenderType"="Transparent" }
		LOD 100
 
		Pass {

            Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 refl : TEXCOORD1;
				float4 pos : SV_POSITION;
			};
			float4 _MainTex_ST;
			v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (pos);
				o.uv = TRANSFORM_TEX(uv, _MainTex);
				o.refl = ComputeScreenPos (o.pos);
				return o;
			}
			fixed4 _MainColor;
			sampler2D _ReflectionTex;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.refl));
				return _MainColor * refl;
			}
			ENDCG
	    }
	}
}