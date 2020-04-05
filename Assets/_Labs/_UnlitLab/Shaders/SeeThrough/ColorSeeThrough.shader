// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/ColorSeeThrough"
{
    Properties
    {
        _Texture("Texture",2D)="white"{}
        _Color("CullColor",Color)=(1.0,1.0,1.0,1.0)
    }

    SubShader
    {
        Tags{"Queue"="Transparent" "RenderType"="Transparent"}
        
   
        Pass//Render occulude part
        {
            Cull off
            ZTest Greater
            ZWrite Off
            

            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

            #include "UnityCG.cginc"
			fixed4 _Color;

			//Data body passing to vertex shader
			struct appdata {
				float4 position:POSITION;//Vertex position in model space
			};
			

            //Vertex Shader function
			float4 vert(appdata v):SV_POSITION
			{                                      
				return UnityObjectToClipPos(v.position);//Convert model space position to clip space position;
			}

            //fragment shader function
			float4 frag() : SV_TARGET0{   
				return fixed4(_Color.rgb,1);
			}
			ENDCG
        }

        Pass//Render visible part
        {
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
