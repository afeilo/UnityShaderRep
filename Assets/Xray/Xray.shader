Shader "Unlit/Xray"
{
	Properties
	{
		_RimColor("RimColor", Color) = (0, 0, 1, 1)
        _RimIntensity("Intensity", Range(0, 2)) = 1
	}
	SubShader
	{
		Tags { 
			"Queue" = "Transparent"
			"RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Blend SrcAlpha One
			ZWrite off
			Lighting off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 normal : NORMAL;
			};

			struct v2f
			{
				float4 color : COLOR;
				float4 vertex : SV_POSITION;
			};

			float _RimIntensity;
			float4 _RimColor;
			//half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 viewDir = normalize(WorldSpaceViewDir(v.vertex));
				float3 normal = mul(unity_ObjectToWorld,v.normal).xyz;
				half rim = 1.0 - saturate(dot(viewDir,normal));
				o.color = _RimColor * pow(rim,_RimIntensity);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = i.color;
				return col;
			}
			ENDCG
		}
	}
}
