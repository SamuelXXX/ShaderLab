﻿Shader "ShaderLab/Lit/Physics/Diffuse"
{
    Properties
    {
        _Diffuse("Diffuse Color",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags{"Queue"="Geometry" "RenderType"="Opaque"}

        Pass  //Shadow Caster Pass
        {
            Name "ShadowCaster"
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f{
                V2F_SHADOW_CASTER;  
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            float4 frag(v2f i):SV_Target 
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }

        Pass//Forward base pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma vertex vert 
            #pragma fragment frag 
            #pragma multi_compile_fwdbase

            fixed4 _Diffuse;

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f 
            {
                float4 pos:SV_POSITION;
                float3 wNormal:TEXCOORD0;
                float3 wViewDir:TEXCOORD1;
                float3 wLightDir:TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.wNormal=UnityObjectToWorldNormal(v.normal);//Convert To World Normal
                o.wViewDir=WorldSpaceViewDir(v.vertex);//Convert to world view 
                o.wLightDir=WorldSpaceLightDir(v.vertex);//Convert to world space light dir

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 wNormal=normalize(i.wNormal);
                fixed3 wLightDir=normalize(i.wLightDir);

                fixed shadow=SHADOW_ATTENUATION(i);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _Diffuse;
                fixed3 diffuse = _Diffuse * _LightColor0 * saturate(dot(wNormal,wLightDir));

                return fixed4(ambient+diffuse*shadow,1);

            }
            ENDCG
        }
    }
}
