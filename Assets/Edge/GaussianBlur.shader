Shader "Unlit/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize ("BlurSize", Float) = 1.0
	}
	CGINCLUDE
	// make fog work
	#pragma multi_compile_fog
	
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv[5] : TEXCOORD0;
		UNITY_FOG_COORDS(1)
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _BlurSize;
	half4 _MainTex_TexelSize;

	// v2f vert (appdata v)
	// {
	// 	v2f o;
	// 	o.vertex = UnityObjectToClipPos(v.vertex);
	// 	o.uv[0] = TRANSFORM_TEX(v.uv, _MainTex);
	// 	o.uv[1] = v.uv + float2(-1*_MainTex_TexelSize.x,0) * _BlurSize;
	// 	o.uv[2] = v.uv + float2(1*_MainTex_TexelSize.x,0) * _BlurSize;
	// 	o.uv[3] = v.uv + float2(-2*_MainTex_TexelSize.x,0) * _BlurSize;
	// 	o.uv[4] = v.uv + float2(2*_MainTex_TexelSize.x,0) * _BlurSize;
	// 	o.uv[5] = TRANSFORM_TEX(v.uv, _MainTex);
	// 	o.uv[6] = v.uv + _MainTex_TexelSize.y * float2(0,-1) * _BlurSize;
	// 	o.uv[7] = v.uv + _MainTex_TexelSize.y * float2(0,1) * _BlurSize;
	// 	o.uv[8] = v.uv + _MainTex_TexelSize.y * float2(0,-2) * _BlurSize;
	// 	o.uv[9] = v.uv + _MainTex_TexelSize.y * float2(0,2) * _BlurSize;
	// 	return o;
	// }

	v2f h_vert (appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv[0] = TRANSFORM_TEX(v.uv, _MainTex);
		o.uv[1] = v.uv + float2(-1*_MainTex_TexelSize.x,0) * _BlurSize;
		o.uv[2] = v.uv + float2(1*_MainTex_TexelSize.x,0) * _BlurSize;
		o.uv[3] = v.uv + float2(-2*_MainTex_TexelSize.x,0) * _BlurSize;
		o.uv[4] = v.uv + float2(2*_MainTex_TexelSize.x,0) * _BlurSize;
		return o;
	}
	
	v2f v_vert (appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv[0] = TRANSFORM_TEX(v.uv, _MainTex);
		o.uv[1] = v.uv + _MainTex_TexelSize.y * float2(0,-1) * _BlurSize;
		o.uv[2] = v.uv + _MainTex_TexelSize.y * float2(0,1) * _BlurSize;
		o.uv[3] = v.uv + _MainTex_TexelSize.y * float2(0,-2) * _BlurSize;
		o.uv[4] = v.uv + _MainTex_TexelSize.y * float2(0,2) * _BlurSize;
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		half weight[3] = {0.4026,0.2442,0.0545};
		fixed3 col = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
		for(int j = 1; j < 3 ;j++){
			col += tex2D(_MainTex, i.uv[j]) * weight[j];
			col += tex2D(_MainTex, i.uv[j*2]) * weight[j];
		}
		
		return fixed4(col,1.0);
	}
	
	ENDCG
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100		
		Pass
		{
			CGPROGRAM
			#pragma vertex h_vert
			#pragma fragment frag
			ENDCG
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex v_vert
			#pragma fragment frag
			ENDCG
		}
	}
}
