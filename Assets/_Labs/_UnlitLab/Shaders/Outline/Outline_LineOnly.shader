// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderLab/Unlit/Outline/Outline_LineOnly"
{
    Properties
    {
        _MainTex("Texture",2D)="white"{}
        _OutlineColor("OutlineColor",Color)=(1.0,1.0,1.0,1.0)
        _OutlineWidth("OutlineWidth",float)=0.01
    }
    SubShader
    {
        Tags{"Queue"="Geometry+10" "RenderType"="Opaque"}//Must render after Geometry Queue

        Pass//Render visible part
        {
            Stencil
            {
                Ref 1
                Comp Always
                Pass replace
            }
            ColorMask 0
        }

        Pass//Outline pass
        {
            Stencil
            {
                Ref 1
                Comp NotEqual
            }
            Cull off
            ZTest LEqual
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _OutlineColor;
            float _OutlineWidth;

            struct appdata{
                float4 position:POSITION;
                float3 normal:NORMAL;
            };


            float4 vert(appdata a):SV_POSITION
            {
                float4 viewPosition = mul(UNITY_MATRIX_MV,a.position);
                float3 viewNormal = mul(UNITY_MATRIX_MV,a.normal);

                viewNormal.z = 0;
                viewNormal=normalize(viewNormal);

                return mul(UNITY_MATRIX_P,viewPosition + float4(viewNormal,0) * _OutlineWidth);
            }

            fixed4 frag():SV_Target
            {
                return _OutlineColor;
            }

            ENDCG
        }

        
    }
}