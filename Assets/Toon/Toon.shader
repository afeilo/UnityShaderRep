Shader "Unlit/Toon"
{Properties
	{
		_MainMap("Main Map",2D) = "white"{}
		_RampMap("_RampMap",2D) = "white"{}
		_SpecularReflectionSampler("_SpecularReflectionSampler",2d) = "white"{}
		_RimColor("RimColor", Color) = (0, 0, 1, 1)
        _RimIntensity("Intensity", Range(0, 0.1)) = 0.01
		_Factor("_Factor", Range(0, 1)) = 0.5
		_ToonFactor("_ToonFactor", Range(0, 1)) = 0.5
		_Steps("_Step",float) = 2
		_Diffuse ("Diffuse Color", Color) = (1,1,1,1)
		_Specular ("Specular Color", Color) = (1,1,1,1)
		_SpecularFactor("_SpecularFactor", Range(0, 5)) = 1
	}
	SubShader
	{
		Tags { 
			"RenderType"="Opaque" }
		LOD 100

		Pass
		{
			ZWrite Off	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex  : POSITION;
				float3 normal  : NORMAL;
			};

			struct v2f
			{
				float4 vertex  : SV_POSITION;
			};
			float _RimIntensity;
			float _Factor;
			float4 _RimColor;
			//half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			v2f vert (appdata v)
			{
				v2f o;
				float3 dir = normalize(v.vertex.xyz);
				float3 dir2 = v.normal;
				dir = dir * sign(dot(dir,dir2));
				dir = lerp(dir,dir2,_Factor);
				v.vertex.xyz += dir*_RimIntensity;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _RimColor;
			}
			ENDCG
		}

		Pass
		{
			Tags { 
			"LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex  : POSITION;
				float2 uv      : TEXCOORD0;
				float3 normal  : Normal;
			};

			struct v2f
			{
				float2 uv       : TEXCOORD0;
				float4 vertex   : SV_POSITION;
				float3 normal   : TEXCOORD1;
				float3 lightDir : TEXCOORD2;
				float3 viewDir  : TEXCOORD3;
			};

			sampler2D _MainMap;
			sampler2D _RampMap;
			sampler2D _SpecularReflectionSampler;
			float _ToonFactor;
			float _Steps;
			float4 _Diffuse;
			float4 _Specular;
			float _SpecularFactor;
			//half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = normalize(v.normal);
				o.lightDir = ObjSpaceLightDir(v.vertex);
				o.viewDir = ObjSpaceViewDir(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 color = tex2D(_MainMap,i.uv);
				//高光
				float3 h = normalize(i.lightDir + i.viewDir);
				float3 specularColor = tex2D(_SpecularReflectionSampler,i.uv);
				float3 specular = specularColor*_Specular.rgb*pow(saturate(dot(i.normal,h)),_SpecularFactor);
				//漫反射

				fixed3 diffuse =  saturate(0.5*dot(i.normal,i.lightDir)+0.5);
				diffuse = smoothstep(0,1,diffuse);
				float toon=floor(diffuse*_Steps)/_Steps;
				// float toon = tex2D(_RampMap,float2(diff,0.5)).r;
				diffuse = lerp(diffuse,toon,_ToonFactor);
				color.xyz = color.rgb * _LightColor0.rbg * _Diffuse.rgb * diffuse + UNITY_LIGHTMODEL_AMBIENT.xyz;
				color.xyz+=specular;
				return color;
			}
			ENDCG
		}
	}
}
