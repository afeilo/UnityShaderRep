// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/UVTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Gloss("Gloss",Range(8,255)) = 20
		_SpecularColor("SpecularColor",Color) = (1,1,1,1)
	}
	SubShader
	{
		// No culling or depth
		Cull off
		
		Tags { 
			"RenderType"="Opaque"
			"LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			float4 _MainTex_ST;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				
				return o;
			}
			
			sampler2D _MainTex;
			float _Gloss;
			fixed4 _SpecularColor;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 col = tex2D(_MainTex, i.uv);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * col;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 diffuse = _LightColor0.rgb * col* saturate(dot(worldNormal,worldLightDir));
				fixed3 halfDir = normalize(worldLightDir+viewDir);
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rbg * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
	}
}
