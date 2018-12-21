Shader "Unlit/XrayNormal"
{
	Properties
	{
		_RimColor("RimColor", Color) = (0, 0, 1, 1)
        _RimIntensity("Intensity", Range(0, 2)) = 1
		_BumpMap("Bump Map",2D) = "white"{}
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
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex  : POSITION;
				float2 uv      : TEXCOORD0;
				float3 normal  : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv     : TEXCOORD0;
				float4 color  : COLOR;
				float4 vertex : SV_POSITION;
				float3 viewDir: TEXCOORD1;
			};

			float _RimIntensity;
			float4 _RimColor;
			sampler2D _BumpMap;
			//half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				TANGENT_SPACE_ROTATION;
				o.viewDir = normalize(mul(rotation,ObjSpaceViewDir(v.vertex)));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uv));
				half rim = 1.0 - saturate(dot(i.viewDir,tangentNormal));
				fixed4 col = _RimColor * pow(rim,_RimIntensity);
				return col;
			}
			ENDCG
		}
	}
}
