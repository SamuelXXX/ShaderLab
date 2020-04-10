// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/Rim/TransparentRim"
{
	Properties
	{
		_Color("RimColor",Color) = (1.0,1.0,1.0,1.0)
		_RimFill("RimFill",Range(-1,1)) = 0
	}
	SubShader
	{
		Tags {"RenderType" = "Transparent" "Queue" = "Transparent-1"}
		Blend SrcAlpha OneminusSrcAlpha

        //Do this pass to write z-buffer only to avoid self-culling problem 
		Pass 
		{
			ZWrite On
			ColorMask 0
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

            #include "UnityCG.cginc"
			fixed4 _Color;
			float _RimFill;

			//Data body passing to vertex shader
			struct appdata {
				float4 position:POSITION;//Vertex position in model space
				float3 normal:NORMAL;//Vertex normal in model space
			};
			
			//Data body coming from vertex shader, and will be interploted and pass to fragment shader
			struct v2f {
				float4 position:SV_POSITION;//Vertex position in normalized cliping space
				float3 viewNormal : POSITION1;//Vertex normal in camera space
				float3 viewPosition: POSITION2;//Vertex position in camera space
			};

            //Vertex Shader function
			v2f vert(appdata v)
			{              
				v2f o;

				o.position = UnityObjectToClipPos(v.position);//Convert model space position to clip space position
				o.viewNormal = mul(UNITY_MATRIX_MV,v.normal);//Convert model space normal direction to camera space direction
				o.viewPosition = mul(UNITY_MATRIX_MV,v.position);//Convert model space position to camera space position
                
                
				return o;
			}

            //fragment shader function
			float4 frag(v2f i) : SV_TARGET{
				float t = 1 + dot(normalize(i.viewNormal), normalize(i.viewPosition)) + _RimFill;//Transparency Factor
				t = saturate(t);
				return fixed4(_Color.rgb,t * _Color.a);
			}
			ENDCG
		}
	}
}
