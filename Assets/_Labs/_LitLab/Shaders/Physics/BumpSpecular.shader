Shader "ShaderLab/Lit/Physics/BumpSpecular"
{
    Properties
    {
        _Diffuse("Diffuse Color",Color)=(1,1,1,1)
        _BumpMap("Normal Map",2D)="bump"{}
        _BumpScale("Bump Scale",Float)=1.0

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
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;

                float3 viewDir:TEXCOORD1;
                float3 lightDir:TEXCOORD2;

                SHADOW_COORDS(4)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW(o);
                o.uv=TRANSFORM_TEX(v.texcoord,_BumpMap);

                TANGENT_SPACE_ROTATION;//Calculate Tangent space rotation matrix
                //float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
                //float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);


                //Transform light direction and view direction to tangent space
                o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag(v2f i):SV_Target
            {
                fixed3 tangentLightDir=normalize(i.lightDir);
                fixed3 tangentViewDir=normalize(i.viewDir);

                fixed4 packedNormal=tex2D(_BumpMap,i.uv);
                fixed3 tangentNormal=UnpackNormal(packedNormal);//Unpack normal texel to a tangent space normal vector
                tangentNormal.xy*=_BumpScale;
                tangentNormal=normalize(tangentNormal);

                fixed3 tangentHalfNormal=normalize(tangentLightDir+tangentViewDir);

                fixed shadow=SHADOW_ATTENUATION(i);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _Diffuse;
                fixed3 diffuse = _Diffuse * _LightColor0 * saturate(dot(tangentNormal,tangentLightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,tangentHalfNormal)),_Gloss); 
                return fixed4(ambient+(diffuse+specular)*shadow,1);

            }
            ENDCG
        }
    }
}
