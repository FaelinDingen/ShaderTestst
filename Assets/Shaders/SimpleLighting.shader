Shader "Unlit/SimpleLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(0,1)) = 1
        _FresnelReflectance ("FresnelReflectance", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include  "AutoLight.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Gloss;
            float _FresnelReflectance;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                //Diffuse Lighting, Lambertian
                float3 N = normalize(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz;
                float3 lambert = saturate(dot(N,L));
                float3 diffuseLight = lambert * _LightColor0;
                
                //Specular lighting, Binn Pong
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 H = normalize(L + V);
                //float3 blinnPhong = saturate(dot(H,N)) * (lambert > 0);
                float3 blinnPhong = saturate(dot(H,N));
                float specularExponent = exp2(_Gloss * 11 + 2);
                float3 specularLight =pow(blinnPhong, specularExponent) * _Gloss;
                specularLight *= _LightColor0;

                //fresnel
                //schlick's aproxamization (more realistic)
                //float3 F0 = _FresnelReflectance; // Base reflectivity at normal incidence
                //float fresnel = F0 + (1 - F0) * pow(1 - dot(V, N), 5);
                //simple fresnel
                //float fresnel = 1-dot(V,N);
                

                
                //specularLight -= fresnel;
                
                //return float4( diffuseLight * _Color + specularLight - fresnel,1);
                return float4( diffuseLight * _Color + specularLight,1 * .5);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }

            Blend One One       // Additive blending
    ZWrite Off          // Don't write to depth buffer
    ZTest LEqual
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include  "AutoLight.cginc"
    
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Gloss;
            float _FresnelReflectance;

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                
                //Diffuse Lighting, Lambertian
                float3 N = normalize(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz - i.wPos;
                float3 lambert = saturate(dot(N,L));
                float3 diffuseLight = lambert * _LightColor0;
                
                //Specular lighting, Binn Pong
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 H = normalize(L + V);
                //float3 blinnPhong = saturate(dot(H,N)) * (lambert > 0);
                float3 blinnPhong = saturate(dot(H,N));
                float specularExponent = exp2(_Gloss * 11 + 2);
                float3 specularLight = pow(blinnPhong, specularExponent) * _Gloss;
                specularLight *= _LightColor0;

                //fresnel
                //schlick's aproxamization (more realistic)
                //float3 F0 = _FresnelReflectance; // Base reflectivity at normal incidence
                //float fresnel = F0 + (1 - F0) * pow(1 - dot(V, N), 5);
                //simple fresnel
                //float fresnel = 1-dot(V,N);
                

                
                //specularLight -= fresnel;
                
                //return float4( diffuseLight * _Color + specularLight - fresnel,1);
                return float4( diffuseLight * _Color + specularLight,1) * .5;
            }
            ENDCG
        }
    }
}
