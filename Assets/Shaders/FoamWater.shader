Shader "VShaders/Nature/FoamWater"
{
	Properties
	{		
        _Color("Color", Color) = (0,0,1,1)
        _IntColor("Intersection Color", Color) = (1,1,1,1)
        _IntThreshold("Intersection Threshold", Float) = 1
        _DispMap("Displacement Map", 2D) = "black" {}
        _DispAmm("Displacement Ammount", Range(0, 3)) = .05
		_Freq("Ripple Frequency", Float) = 10
        _Amp("Ripple Amplitude", Float) = 10
        _Thickness("Ripple Thickness", Range(0, .5)) = .1
		_RDispAmm("Ripple Displacement Ammount", Range(0, 3)) = .05
	}
	SubShader
	{
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		Cull Off ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
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
                float4 scrPos : TEXCOORD1;
			};

			float _Freq;
			float _Amp;
			float _Thickness;
            fixed4 _Color;
            fixed4 _IntColor;
            float _IntThreshold;
            sampler2D _DispMap;
            float _DispAmm;
			float _RDispAmm;

            sampler2D _CameraDepthTexture;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                o.scrPos = ComputeScreenPos(o.vertex);
				return o;
			}

			inline float step(float l, float g, float v){
				return step(l, v) * step(v, g);
			}

			inline float2 sample_displacement(sampler2D map, float2 uv, float2 speed, float magnitude){
				float2 d = tex2D(map, uv + speed * _Time.y) * 2 -1;
				return d * magnitude;
			}			

			inline float ripple(v2f i){
				float2 disp = sample_displacement(_DispMap, i.uv, .001, _RDispAmm);

                float2 st = i.uv * 2 - 1 + disp;
                float d = st.x * st.x + st.y * st.y;
				float c = d * _Amp + _Time.y * _Freq;				
				float col = step(.5 - _Thickness, .5 + _Thickness, frac(c));
				float a = round((1 - d - .5) * 10) / 10;
				col = col * a;
				return saturate(col);
			}

			
			fixed4 frag (v2f i) : SV_Target
			{				
                float2 t = _Time.x;
                float2 disp = tex2D(_DispMap, i.uv + t).rg * 2 - 1;
                disp *= _DispAmm;

                float depth = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
                float diff = saturate(_IntThreshold * (depth - i.scrPos.w) + disp);
				float r = ripple(i);

				return lerp(_IntColor, _Color, step(.5, diff)) + r * _IntColor;
			}
			ENDCG
		}
	}
}
