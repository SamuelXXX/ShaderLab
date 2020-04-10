Shader "ShaderLab/Unlit/SeeThrough/Color_CullOnly"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags{"Queue"="Transparent+1" "RenderType"="Transparent"}

        Pass//Use this pass to mark visible body part
        { 
            ZTest Equal
            ZWrite Off
            Stencil
            {
                Ref 112
                Comp Always
                Pass replace
            }
            ColorMask 0
        }
        Pass 
        { 
            Stencil
            {
                Ref 112
                Comp NotEqual
            }
            ZTest Greater
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"
            fixed4 _Color;

            struct appdata
            {
                float4 position:POSITION;
            };

            struct v2f 
            {
                float4 position:SV_POSITION;
            };

            v2f vert(appdata i)
            {
                v2f o;
                o.position=UnityObjectToClipPos(i.position);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                return _Color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
