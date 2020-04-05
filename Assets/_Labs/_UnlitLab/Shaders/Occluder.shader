// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/Occluder"
{

    SubShader
    {
        Tags{"Queue"="Geometry-1" "RenderType"="Transparent"}
        

        Pass//Accumulate back face numbers of occlude part
        {
            ZWrite On
            ColorMask 0         
        }
    }
}
