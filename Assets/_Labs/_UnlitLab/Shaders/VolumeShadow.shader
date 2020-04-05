// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/VolumeShadow"
{
    Properties
    {
        _ShadowColor("ShadowColor",Color)=(0,0,0,1)
    }

    SubShader
    {
        Tags{"Queue"="Geometry+5" "RenderType"="Transparent"}
        

        Pass//Accumulate back face numbers of occlude part
        {
            Cull front 
            Stencil {
                Ref 1           
                Comp Always     
                Pass IncrSat      
            }
            ZTest Greater
            ZWrite Off
            ColorMask 0         
        }
        
        Pass//Accumulate occlude front face of occlude part
        {
            cull back
            Stencil {
                Ref 1           
                Comp Always     
                Pass DecrSat      
            }
            ZTest Greater
            ZWrite Off
            ColorMask 0         
        }

        Pass//Recalculate depth for alpha blending
        {
            Cull front 
            ZTest Greater
            ZWrite On
            ColorMask 0         
        }
        
        Pass
        {
            Cull front
            Stencil {
                Ref 1          //0-255
                Comp LEqual     //default:always
            }
            ZTest Equal
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _ShadowColor;

            float4 vert (float4 position:POSITION):SV_POSITION
            {
                return UnityObjectToClipPos(position);
            }
        
            fixed4 frag () : SV_Target
            {
                return fixed4(_ShadowColor.rgb,_ShadowColor.a);           //影子颜色
            }
            ENDCG
        }
    }
}
