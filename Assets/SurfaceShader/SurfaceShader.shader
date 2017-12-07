Shader "Custom/SurfaceShader" {
	Properties {
		_MainTex("Texture",2D) = "white"{}
		_BumpMap("BumpMap",2D) = "bump"{}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert
		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};


		sampler2D _MainTex;
		sampler2D _BumpMap;
		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			o.Albedo = tex2D(_MainTex,IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
