Shader "ShaderLab/Lit/Physics/Diffuse"
{
    Properties
    {
        _MainTex("Base (RGB)",2D)="white"{}
        _Diffuse("Diffuse Color",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags{"Queue"="Geometry" "RenderType"="Opaque"}
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma vertex vert 
            #pragma fragment frag 

            sampler2D _MainTex;
            fixed4 _Diffuse;

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
                float4 uv:TEXCOORD0;
            };

            v2f vert(appdata i)
            {
                v2f o;
                o.position=UnityObjectToClipPos(i.position);
                o.wNormal=UnityObjectToWorldNormal(i.normal);//Convert To World Normal
                o.wViewDir=WorldSpaceViewDir(i.position);//Convert to world view 
                o.wLightDir=WorldSpaceLightDir(i.position);//Convert to world space light dir
                o.uv=i.uv;
                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed4 baseColor=tex2D(_MainTex,i.uv)*_Diffuse;
                

                fixed3 wNormal=normalize(i.wNormal);
                fixed3 wLightDir=normalize(i.wLightDir);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * baseColor.rgb;
                fixed3 diffuse = baseColor.rgb * _LightColor0 * saturate(dot(wNormal,wLightDir));

                return fixed4(ambient+diffuse,1);

            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
