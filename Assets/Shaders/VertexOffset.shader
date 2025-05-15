Shader "Unlit/VertexOffset"
{
    Properties
    {
        _StartColor ("StartColor", Color) = (1,1,1,1)
        _EndColor ("EndColor", Color) = (1,1,1,1)
        
        _WaveIntencity ("WaveIntencity", float) = 5
        _WaveHeight ("WaveHeight", float) = 5
        _HorizontalScrollSpeed ("HorizontalScrollSpeed", float) = 10
        _VerticalScrollSpeed ("VerticalScrollSpeed", float) = .1
        _WaveAmplitude ("WaveAmplitude", Range(0,5)) = .1
        _Radial ("Radial", int) = 0
    }
    SubShader{
        Tags { 
            "RenderType"="Opaque" 
            "Queue"="Geometry"
            //"RenderType"="Transparent" 
            //"Queue"="Transparent"
        }

        Pass{
            //Blend DstColor Zero
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283
            
            float4 _StartColor;
            float4 _EndColor;

            float _WaveIntencity;
            float _WaveHeight;
            float _HorizontalScrollSpeed;
            float _VerticalScrollSpeed;
            float _WaveAmplitude;
            bool _Radial;

            struct MeshData // per vertex mesh data
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXTCOORD0;
                float2 uv : TEXTCOORD1;
                //float2 uv : TEXCOORD0;
            };

            float GetWave(float2 uv)
            {
                float2 uvCentered = uv * 2 - 1;
                float radialDistance = length(uvCentered);
                float wave = cos(((_Radial ? radialDistance : uv.y) - _Time.y * _VerticalScrollSpeed) * TAU * _WaveHeight) * .5 + .5;
                wave *= 1 - (_Radial ? radialDistance : 0);
                return wave;
            }
            
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                v.vertex.y = GetWave(v.uv0) * _WaveAmplitude;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float waves = saturate(GetWave(i.uv));
                return _EndColor * waves + _StartColor * (1 - waves);
            }
            ENDCG
        }
    }
}
