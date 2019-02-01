Shader "VShaders/Effects/TwoSidedDissolve"
{
	Properties
	{		
        _DissolveMap("Dissolve Map", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque"}

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
                fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
			};

            sampler2D _DissolveMap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{			
                float a = tex2D(_DissolveMap, i.uv).r - (1 - i.color.a);
                clip(a);	
				return i.color;
			}
			ENDCG
		}
	}
}
