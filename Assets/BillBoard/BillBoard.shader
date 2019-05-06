// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/BillBoard"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_VerticalBillboarding("VerticalBillboarding",Range (0, 1)) = 0
	}
	SubShader
	{
		Tags {"IgnoreProject" = "True" "RenderType"="Transparent" }
		LOD 100
		Cull off
		//关闭深度写入
		ZWrite off
		//开启并设置混合模式
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _VerticalBillboarding;
			
			v2f vert (appdata v)
			{
				v2f o;
				float3 center = float3(0,0,0);
				float3 viewDir = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
				viewDir = viewDir - center;
				viewDir.y = lerp(0,viewDir.y,_VerticalBillboarding);
				viewDir = normalize(viewDir);
				float3 upDir = abs(viewDir.y) > 0.999f ? float3(0,0,1) : float3(0,1,0);
				float3 rightDir = normalize(cross(upDir,viewDir));
				upDir = normalize(cross(viewDir,rightDir));
				float3 pos = rightDir * v.vertex.x + upDir * v.vertex.y + viewDir * v.vertex.z;
				o.vertex = UnityObjectToClipPos(float4(pos,1));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
