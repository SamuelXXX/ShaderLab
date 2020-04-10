Shader "ShaderLab/Unlit/SeeThrough/RimSeeThrough1_CullOnly"
{
    Properties
    {
        _RimColor("RimColor",Color)=(1,1,1,1)
        _RimFill("RimFill",Range(-1,1)) = 0
    }
    SubShader
    {
        Tags{"Queue"="Transparent+1" "RenderType"="Transparent"}

        Pass //Mark Not Occulude part
        {
            Stencil 
            {
                Ref 113
                Comp Always 
                Pass replace
            }
            ZTest Equal
            ZWrite Off 
            ColorMask 0
        }

        //Rewrite Z-buffer within following 2 passes
        Pass 
        {
            Stencil 
            {
                Ref 113
                Comp NotEqual 
            }
            ZTest Greater 
            ZWrite On
            ColorMask 0
        }

        Pass 
        {
            Stencil 
            {
                Ref 113
                Comp NotEqual 
            }
            ZTest Less 
            ZWrite On
            ColorMask 0
        }

        Pass 
        {
            Stencil 
            {
                Ref 113
                Comp NotEqual 
            }
            ZTest Equal 
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"

            fixed4 _RimColor;
			float _RimFill;

			//Data body passing to vertex shader
			struct appdata {
				float4 position:POSITION;//Vertex position in model space
				float3 normal:NORMAL;//Vertex normal in model space
			};
			
			//Data body coming from vertex shader, and will be interploted and pass to fragment shader
			struct v2f {
				float4 position:SV_POSITION;//Vertex position in normalized cliping space
				float3 wNormal : POSITION1;//Vertex normal in world space
				float3 wViewDir: POSITION2;//Vertex view direction in world space
			};

            //Vertex Shader function
			v2f vert(appdata v)
			{              
				v2f o;

				o.position = UnityObjectToClipPos(v.position);//Convert model space position to clip space position
				o.wNormal=UnityObjectToWorldNormal(v.normal);//Convert model space position to world space normal
				o.wViewDir = WorldSpaceViewDir(v.position);//Convert model space position to world space position
                
                
				return o;
			}

            //fragment shader function
			float4 frag(v2f i) : SV_TARGET0{               
				float t = 1 - dot(normalize(i.wNormal), normalize(i.wViewDir)) + _RimFill;//Transparency Factor
				t = saturate(t);
                //return fixed4(normalize(i.wViewDir),1);
				return fixed4(_RimColor.rgb,t * _RimColor.a);
			}

            ENDCG
        }
    }
}