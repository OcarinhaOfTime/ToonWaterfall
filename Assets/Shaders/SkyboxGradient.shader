Shader "VShaders/Skyboxes/SkyboxGradient"
{
	Properties
	{
		_Color1("Bottom Color", Color) = (1,1,1,1)
		_Color2("Top Color", Color) = (0,0,0,0)
		_UpVector("Up Vector", Vector) = (0,1,0,0)

		_Intensity("Intensity", Float) = 1
		_Exponent("Exponent", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Background" "Queue"="Background" "PreviewType"="Skybox"}
		Cull Off ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 view_dir : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 view_dir : TEXCOORD0;
			};

			fixed4 _Color1;
			fixed4 _Color2;
			float3 _UpVector;

			float _Intensity;
			float _Exponent;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.view_dir = v.view_dir;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{				
				fixed d = dot(normalize(i.view_dir), _UpVector) *.5 + .5;
				return lerp(_Color1, _Color2, pow(d, _Exponent)) * _Intensity;
			}
			ENDCG
		}
	}
}
