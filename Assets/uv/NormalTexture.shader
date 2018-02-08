Shader "Hidden/NormalTexture"
{
	//1.计算切线空间
	//2.将光方向以及视角方向转换到切线空间
	//3.跟进normalmap计算出切线空间的法线向量
	//4.计算出漫反射以及高光反射
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap("Bump Map",2D) = "white"{}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
		_Alpha("Alpha",Range(0,1))= 1
	}
	SubShader
	{
		// No culling or depth
		// ZTest off
		ZWrite off
		Blend srcAlpha OneMinusSrcAlpha,one zero
		Pass
		{
			Tags { 
			"LightMode"="ForwardBase" }
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _BumpMap;
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			float _Alpha;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
				o.uv.zw = v.uv*_BumpMap_ST.xy+_BumpMap_ST.zw;
				// float3 binormal = cross(v.normal,v.tangent.xyz)*v.tangent.w;
				// float3x3 ratation= float3x3(v.tangent.xyz,binormal,v.normal);
				TANGENT_SPACE_ROTATION;
				o.lightDir = normalize(mul(rotation,ObjSpaceLightDir(v.vertex).xyz));
				o.viewDir = normalize(mul(rotation,ObjSpaceViewDir(v.vertex).xyz));
				return o;
			}
			

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				//切线空间的法线
				fixed3 tangentNormal;
				tangentNormal.xy = (packedNormal.xy*2-1)*_BumpScale;
				tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				fixed3 col = tex2D(_MainTex, i.uv.xy);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * col;
				fixed3 diffuse = _LightColor0.rgb*col*saturate(dot(tangentNormal,i.lightDir));
				fixed3 halfuse = normalize(i.lightDir+i.viewDir);
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(tangentNormal,halfuse)),_Gloss);
				// just invert the colors
				return fixed4(ambient+diffuse+specular,_Alpha);
			}
			ENDCG
		}
	}
}
