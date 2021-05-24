Shader "Jung/PrimitiveSphere"
{
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

#define STEPS 128
#define STEP_SIZE 0.01

			bool SphereHit(float3 p, float3 center, float radius) {
				return distance(p, center) < radius;
			}

			float3 RaymarchHIt(float3 position, float3 direction)
			{
				for (int i = 0; i < STEPS; i++)
				{
					if (SphereHit(position, float3(0, 0, 0), 0.5)) {
						return position; // the depth in which we hit
					}

					position += direction * STEP_SIZE;
				}

				return float3(0, 0, 0); // didn't hit anything
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
				float3 worldPos = i.wPos;
				float3 depth = RaymarchHIt(worldPos, viewDir);

				if (length(depth) != 0) {
					return fixed4(depth.x, depth.y, depth.z, 1);
				}
				else {
					return fixed4(1, 1, 1, 0);
				}
			}
			ENDCG
		}
	}
}
