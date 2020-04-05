// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/RimSeeThrough1"
{
    Properties
    {
        _Texture("Texture",2D)="white"{}
        _Color("CullColor",Color)=(1.0,1.0,1.0,1.0)
        _RimFill("RimFill",Range(-1,1)) = 0
    }

    SubShader
    {
        Tags{"Queue"="Transparent+2" "RenderType"="Transparent"}
        
        //Three stencil Value
        //Occulude by other object: 8
        //Occulude other object: 9

        Pass//Write stencil buffer of occulude part
        {
            Stencil
            {
                Ref 8
                Comp Always
                Pass replace
                ZFail keep
            }//Set occulude part stencil value to 8
            ZTest Greater
            ZWrite Off
            ColorMask 0
        }

        Pass
        {
            Stencil
            {
                Ref 9
                Comp Always
                Pass replace
                ZFail keep
            }//Set visible part stencil value to 9
            ZTest Less
            ZWrite Off
            ColorMask 0
        }

        //Rewrite Z Depth Buffer in the following 2 passes
        Pass//Write Z Buffer to farthest point
        {
            ZTest Greater
            ZWrite On
            ColorMask 0
        }

        Pass//Rewrite Z buffer to closest point
        {
            ZTest Less
            ZWrite On
            ColorMask 0
        }

        
        Pass//Render occulude part
        {
            Stencil
            {
                Ref 8
                Comp Equal
            }

            ZTest Equal
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha
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
			float4 frag(v2f i) : SV_TARGET0{               
				float t = 1 + dot(normalize(i.viewNormal), normalize(i.viewPosition)) + _RimFill;//Transparency Factor
				t = saturate(t);
				return fixed4(_Color.rgb,t * _Color.a);
			}
			ENDCG
        }

        Pass//Render visible part
        {
            Stencil
            {
                Ref 9
                Comp Equal
            }
            ZTest Equal
            ZWrite Off
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _Texture;
            int _ShowVisible;
            
            struct appdata{
                float4 position:POSITION;
                float2 uv:TEXCOORD;
            };

            struct v2f{
                float4 position:SV_POSITION;
                float2 uv:TEXCOORD;
            };

            v2f vert(appdata i)
            {
                v2f o;
                o.position=UnityObjectToClipPos(i.position);
                o.uv=i.uv;
                return o;
            }

            float4 frag(v2f i):SV_Target{
                return tex2D(_Texture,i.uv);
            }

            ENDCG
        }        
    }
}
