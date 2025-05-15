Shader "Unlit/HealthBar"
{
    Properties
    {
        [NoScaleOffset] _HealthBarTexture ("HeathbarTexture", 2D) = "white" {}
        _StartColor ("StartColor", Color) = (0,1,0,1)
        _EndColor ("EndColor", Color) = (1,0,0,1)
        _HealthValue ("health", Range(0,1)) = 1
        _BorderColor ("BorderColor", Color) = (0,0,0,1)
        _BorderStrength ("BorderStrength", Range(0,1)) = 1
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

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float flash : TEXCOORD1;
            };
            sampler2D _HealthBarTexture;
            float4 _StartColor;
            float4 _EndColor;
            float _HealthValue;
            float4 _MainTex_ST;
            float _BorderStrength;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv0;
                
                //flash on low health
                o.flash = sin(_Time.y * 5) * .5 + 1;
                
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            float3 GetObjectScale()
            {
                return float3(
                length(unity_ObjectToWorld._m00_m10_m20), // X scale
                length(unity_ObjectToWorld._m01_m11_m21), // Y scale
                length(unity_ObjectToWorld._m02_m12_m22)  // Z scale
                );
            }

            float3 GetScaleFromWorldMatrix(float4x4 worldMatrix)
            {
                float3 scale;
                scale.x = length(worldMatrix[0].xyz); // Length of the X-axis vector
                scale.y = length(worldMatrix[2].xyz); // Length of the Y-axis vector
                scale.z = length(worldMatrix[1].xyz); // Length of the Z-axis vector
                return scale;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float2 uniform_uv = float2(i.uv.x * GetScaleFromWorldMatrix(unity_ObjectToWorld).x / GetScaleFromWorldMatrix(unity_ObjectToWorld).y, i.uv.y);
                float maxX = GetScaleFromWorldMatrix(unity_ObjectToWorld).x / GetScaleFromWorldMatrix(unity_ObjectToWorld).y;
                float2 pointOnLineSegment = float2(clamp(uniform_uv.x,.5, maxX - .5),.5);
                float sdf = distance(pointOnLineSegment, uniform_uv) * 2 - 1;
                clip(-sdf);
                float borderSdf = sdf + _BorderStrength;
                float borderMask = step(0, -borderSdf);
                //return float4(borderMask.xxx,1);
                
                float4 col = tex2D(_HealthBarTexture, float2(saturate(InverseLerp(.2, .8, _HealthValue)), i.uv.y));
                
                float4 finalColor = step(i.uv.x, _HealthValue) * col;

                //make the backs transparent
                //clip(finalColor.a - .01);
                
                finalColor *= (_HealthValue < 0.3 ? i.flash : 1);
                return finalColor * borderMask;
            }
            ENDCG
        }
    }
}
