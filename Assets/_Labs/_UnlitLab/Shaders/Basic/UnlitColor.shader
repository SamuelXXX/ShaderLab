// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/Basic/UnlitColor"
{
    Properties
    {
        _Color("Color",Color)=(1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags{"Queue"="Geometry" "RenderType"="Opaque"}
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            float4 _Color;

            float4 vert(float4 pos:POSITION):SV_POSITION
            {
                return UnityObjectToClipPos(pos);
            }

            float4 frag():SV_TARGET
            {
                return _Color;
            }
            ENDCG
        }
    }
    FallBack "Unlit/Color"
}
