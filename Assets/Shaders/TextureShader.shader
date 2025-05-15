Shader "Unlit/TextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _StartTex ("StartTexture", 2D) = "white" {}
        _EndTex ("EndTexture", 2D) = "black" {}
        _MipLevel ("Mip", Float) = 0
        
        _StartColor ("StartColor", Color) = (1,1,1,1)
        _EndColor ("EndColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 wordPos : TEXTCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _StartTex;
            sampler2D _EndTex;
            float _MipLevel;
            float4 _MainTex_ST;

            float GetWave(float2 uv)
            {
                float2 uvCentered = uv * 2 - 1;
                float wave = cos((uvCentered - _Time.y * .01) * TAU * 5) * .5 + .5;
                return wave;
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.wordPos = mul(UNITY_MATRIX_M, v.vertex);      //transforms local space to world space
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.wordPos.xz;
                
                //return float4(topDownProjection,0 , 1);

                // return float4(tex2Dlod(_StartTex, float4(topDownProjection, _MipLevel.xx)));
                
                fixed4 col = tex2D(_MainTex, topDownProjection);
                float patern = tex2D(_MainTex, i.uv).x;
                float4 startTex = tex2D(_StartTex, topDownProjection);
                float4 endTex = tex2D(_EndTex, topDownProjection);
                float4 finalColor = lerp(startTex, endTex, patern);
                return finalColor;
            }
            ENDCG
        }
    }
}
