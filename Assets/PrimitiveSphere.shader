Shader "Jung/PrimitiveSphere"
{
	Properties
	{
		_Steps("Steps", Range(0.1, 300)) = 128
		_StepSize("Step Size", Range(0.001, 5)) = 0.01
		_SpherePos("Sphere Pos", Vector) = (0, 0, 0, 1)
		_SphereRadius("Sphere Radius", Range(0.1, 5)) = 1
	}

		SubShader
	{
		Tags { "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 wPos : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			float _Steps;
			float _StepSize;
			float4 _SpherePos;
			float _SphereRadius;

			bool SphereHit(float3 p, float3 center, float radius) {
				return distance(p, center) < radius;
			}

			float3 RaymarchHIt(float3 position, float3 direction)
			{
				for (int i = 0; i < _Steps; i++)
				{
					if (SphereHit(position, _SpherePos.xyz, _SphereRadius)) {
						return position; // the depth in which we hit
					}

					position += direction * _StepSize;
				}

				return float3(0, 0, 0); // didn't hit anything
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
				float3 worldPos = i.wPos;
				float3 depth = RaymarchHIt(worldPos, viewDir);

				half3 worldNormal = depth - _SpherePos;
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));

				if (length(depth) != 0) {
					depth *= nl * _LightColor0;
					return fixed4(depth, 1);
				}
				else {
					return fixed4(1, 1, 1, 0);
				}
			}
			ENDCG
		}
	}
}
