Shader "Unlit/Edge"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeColor("EdgeColor",COLOR) = (0,0,0,0)
		_BackgroundColor("BackgroundColor",COLOR) = (0,0,0,0)
		_EdgeFill("EdgeFill",Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
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
				float2 uv[9] : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			half4 _MainTex_TexelSize;
			float4 _MainTex_ST;
			float4 _EdgeColor;
			float _EdgeFill;
			float4 _BackgroundColor;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				half2 uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv[0] = uv + _MainTex_TexelSize * fixed2(-1,-1);
				o.uv[1] = uv + _MainTex_TexelSize * fixed2(0,-1);
				o.uv[2] = uv + _MainTex_TexelSize * fixed2(1,-1);
				o.uv[3] = uv + _MainTex_TexelSize * fixed2(-1,0);
				o.uv[4] = uv + _MainTex_TexelSize * fixed2(0,0);
				o.uv[5] = uv + _MainTex_TexelSize * fixed2(1,0);
				o.uv[6] = uv + _MainTex_TexelSize * fixed2(1,-1);
				o.uv[7] = uv + _MainTex_TexelSize * fixed2(1,0);
				o.uv[8] = uv + _MainTex_TexelSize * fixed2(1,1);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			// 计算饱和度
			fixed lumicance(fixed4 color){
				return 0.2125*color.r + 0.7154*color.g + 0.0721*color.b;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				const half Gx[9] = {-1,-2,-1,
									0,0,0,
									1,2,1};
				const half Gy[9] = {-1,0,1,
									-2,0,2,
									-1,0,1};	
				
				half edgex = 0;
				half edgey = 0;
				half lum;
				for(int j = 0; j < 9 ;j++){
					lum = lumicance(tex2D(_MainTex,i.uv[j]));
					edgex += lum*Gx[j]*0.5;
					edgey += lum*Gy[j]*0.5; 
				}			
				half edge = abs(edgex) + abs(edgey);
				fixed4 withEdgeColor = lerp(tex2D(_MainTex,i.uv[4]),_EdgeColor,edge);
				fixed4 onlyEdgeColor = lerp(_BackgroundColor,_EdgeColor,edge);
				fixed4 col = lerp(withEdgeColor,onlyEdgeColor,_EdgeFill);
				return col;
			}
			ENDCG
		}
	}
}
