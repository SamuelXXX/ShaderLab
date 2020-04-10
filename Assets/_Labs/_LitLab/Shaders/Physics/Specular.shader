Shader "ShaderLab/Lit/Physics/Specular"
{
    Properties
    {
        _MainTex("Base (RGB)",2D)="white"{}
        _Diffuse("Diffuse Color",Color)=(1,1,1,1)

        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,255))=20
    }
    SubShader
    {
        Tags{"Queue"="Geometry" "RenderType"="Opaque"}
        Pass 
        {
            Tags{"Queue"="Geometry" "RenderType"="Opaque"}
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma vertex vert 
            #pragma fragment frag 

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct appdata 
            {
                float4 position:POSITION;
                float3 normal:NORMAL;
                float4 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 position:SV_POSITION;
                float3 wNormal:POSITION1;
                float3 wViewDir:POSITION2;
                float3 wLightDir:POSITION3;

                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata i)
            {
                v2f o;
                o.position=UnityObjectToClipPos(i.position);
                o.wNormal=UnityObjectToWorldNormal(i.normal);
                o.wViewDir=WorldSpaceViewDir(i.position);
                o.wLightDir=WorldSpaceLightDir(i.position);
                o.uv=TRANSFORM_TEX(i.uv,_MainTex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target 
            {
                fixed4 baseColor=tex2D(_MainTex,i.uv)*_Diffuse;

                fixed3 wNormal=normalize(i.wNormal);
                fixed3 wLightDir=normalize(i.wLightDir);
                fixed3 wViewDir=normalize(i.wViewDir);
                fixed3 wReflectDir=normalize(reflect(-wLightDir,wNormal));
                fixed3 wHalfDir=normalize(wLightDir+wViewDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * baseColor.rgb;
                fixed3 diffuse = baseColor.rgb * _LightColor0 * saturate(dot(wNormal,wLightDir));
                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(wNormal,wHalfDir)),_Gloss);
                return fixed4(ambient+diffuse+specular,1);

            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
