Shader "ShaderLab/Lit/Physics/Specular"
{
    //Use Blinn-Phong light model for specular light calculation
    Properties
    {
        _Diffuse("Diffuse Color",Color)=(1,1,1,1)
        _Specular("Specular Color",Color)=(1,1,1,1)

        _Gloss("Gloss",Range(8,255))=20
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

        Pass //Forward base pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma vertex vert 
            #pragma fragment frag 
            #pragma multi_compile_fwdbase //Make sure to access the right lighting parameters

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

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
                SHADOW_COORDS(3)//Coordinate uv to sample screen space shadow map
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.wNormal=UnityObjectToWorldNormal(v.normal);
                o.wViewDir=WorldSpaceViewDir(v.vertex);
                o.wLightDir=WorldSpaceLightDir(v.vertex);
                TRANSFER_SHADOW(o);//Get the value of screen space shadow map coordinate
                return o;
            }

            fixed4 frag(v2f i):SV_Target 
            {
                fixed3 wNormal=normalize(i.wNormal);
                fixed3 wLightDir=normalize(i.wLightDir);
                fixed3 wViewDir=normalize(i.wViewDir);

                fixed3 wHalfDir=normalize(wLightDir+wViewDir);//For blinn-phong light model

                fixed shadow=SHADOW_ATTENUATION(i);//Calculate shadow value from screen space shadow map

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _Diffuse;
                fixed3 diffuse =  _Diffuse.rgb * _LightColor0.rgb * saturate(dot(wNormal,wLightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(wNormal,wHalfDir)),_Gloss); 

                return fixed4(ambient+(diffuse+specular)*shadow,1);

            }
            ENDCG
        }
    }
}
