Shader "Custom/WrapLambert" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf WrapLambert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		half4 LightingWrapLambert(SurfaceOutput s,half3 lightDir, half atten){
			fixed diff = max(0,dot(s.Normal,lightDir));
			// diff = diff * 0.5 + 0.5;
			fixed4 c;
			c.rgb = s.Albedo * _LightColor0.rgb*(diff);
			c.a = s.Alpha;
			return c;
		}
		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 color = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = color.rgb;
			// Metallic and smoothness come from slider variables
			o.Alpha = color.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
