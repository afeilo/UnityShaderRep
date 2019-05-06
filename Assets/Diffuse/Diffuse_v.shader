// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Diffuse_v"
{
	Properties
	{
		_Diffuse ("Diffuse Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		LOD 100

		Pass
		{
			Tags { 
			"LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldLight : TEXCOORD1;
			};

			fixed4 _Diffuse;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = v.normal;//normalize(mul(v.normal,(fixed3x3)unity_WorldToObject));
				o.worldLight = ObjSpaceLightDir(v.vertex);;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 diffuse = _LightColor0.rbg * _Diffuse.rgb * saturate(0.5*dot(i.worldNormal,i.worldLight)+0.5);
				fixed4 color = fixed4(UNITY_LIGHTMODEL_AMBIENT.xyz+diffuse,1.0f);
				return color;
			}
			ENDCG
		}
	}
}
