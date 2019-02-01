Shader "VShaders/Nature/Waterfall"
{
	Properties
	{		
        _NoiseTex("Noise Texture", 2D) = "white"{}
        _DispMap("Displacement Texture", 2D) = "white"{}
        _DispAmm("Displacement Ammount", Range(0, .1)) = 0.05
        _TopDark("Top Dark Color", Color) = (0, 0, 0, 0)
        _BottomDark("Bottom Dark Color", Color) = (0, 0, 0, 0)
        _TopLight("Top Light Color", Color) = (1,1,1,1)
        _BottomLight("Bottom Light Color", Color) = (1,1,1,1)
        _FoamColor("Foam Color", Color) = (1,1,1,1)
        _FoamThreshold("Foam Threshold", Range(0, 1)) = .1
	}
	SubShader
	{
		Pass
		{			
			Tags { "RenderType"="Opaque"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

            sampler2D _NoiseTex;
            sampler2D _DispMap;
            float _DispAmm;

            half4 _TopDark;
            half4 _BottomDark;
            half4 _TopLight;
            half4 _BottomLight;
            half4 _FoamColor;

            float _FoamThreshold;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{				
                float2 t = float2(0, _Time.y * .2);
                float2 disp = tex2D(_DispMap, i.uv + t).rg * 2 - 1;
                disp *= _DispAmm;
                
                float n = tex2D(_NoiseTex, i.uv * float2(1, .1) + t + disp).r;
                n = round(n * 5) / 5;
                fixed4 dark = lerp(_BottomDark, _TopDark, i.uv.y);
                fixed4 light = lerp(_BottomLight, _TopLight, i.uv.y);

                fixed4 col = lerp(dark, light, n);
                col = lerp(_FoamColor, col, step(_FoamThreshold, i.uv.y + disp.y));

				return col;
			}
			ENDCG
		}		

		Pass
        {
			Tags {"LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
 
            struct v2f {
                V2F_SHADOW_CASTER;
            };
 
            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
 
            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
	}
	FallBack "Diffuse"
}
