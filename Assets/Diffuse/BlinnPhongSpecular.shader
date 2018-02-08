// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/BlinnPhongSpecular"
{
	Properties
	{
		_Gloss ("Gloss",Range(8,256)) = 20
		_Specular("Specular",Color) = (1,1,1,1)
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { 
			"RenderType"="Opaque"
			"LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
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
				fixed4 color : Color;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			fixed4 _Specular;
			fixed4 _Diffuse;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld,v.normal));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
				fixed3 halfDir = normalize(viewDir+worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb *pow(saturate(dot(worldNormal,halfDir)),_Gloss);
				o.color = fixed4(UNITY_LIGHTMODEL_AMBIENT.xyz+diffuse+specular,1.0f);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return i.color;
			}
			ENDCG
		}
	}
}
