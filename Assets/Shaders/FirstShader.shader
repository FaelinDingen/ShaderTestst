Shader "Unlit/First_Shader"
{
    Properties
    {
        _StartColor ("StartColor", Color) = (1,1,1,1)
        _EndColor ("EndColor", Color) = (1,1,1,1)
        
        _WaveIntencity ("WaveIntencity", float) = 5
        _WaveHeight ("WaveHeight", float) = 5
        _HorizontalScrollSpeed ("HorizontalScrollSpeed", float) = 10
        _VerticalScrollSpeed ("VerticalScrollSpeed", float) = .1
    }
    SubShader{
        Tags { 
            "RenderType"="Transparent" 
            "Queue"="Transparent"
        }

        Pass{
            ZWrite Off
            Blend one One
            Cull Off
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

            Interpolators vert (MeshData v)
            {
                Interpolators o;
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
                float offset = cos(i.uv.x * TAU * _WaveIntencity + (-_Time.y * _HorizontalScrollSpeed)) * .01;
                float t = cos((i.uv.y + offset + -_Time.y * _VerticalScrollSpeed) * TAU * _WaveHeight);
                t = t * (1 - i.uv.y) * i.uv.y;

                float topBottomRemover = (abs(i.normal.y) < 0.999);
                float waves = saturate(t) * topBottomRemover;

                float4 gradient = lerp(_StartColor, _EndColor, i.uv.y);
                
                return gradient * waves;
            }
            ENDCG
        }
    }
}
