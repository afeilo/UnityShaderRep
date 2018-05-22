Shader "Unlit/ColorAdjustEffect"
//亮度、饱和度、对比度学习
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Brightness("Brightness", Float) = 1  
        _Saturation("Saturation", Float) = 1  
        _Contrast("Contrast", Float) = 1  
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
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _Brightness;  
            half _Saturation;  
            half _Contrast;  

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// 计算亮度
				fixed3 finalCol = col * _Brightness;
				// 计算饱和度因子
				fixed gray = 0.2125*col.r + 0.7154*col.g + 0.0721*col.b;
				fixed3 grayColor = fixed3(gray,gray,gray);
				finalCol = lerp(grayColor,finalCol,_Saturation);
				// 计算对比度
				finalCol = lerp(fixed3(0.5,0.5,0.5),finalCol,_Contrast);
				return fixed4(finalCol,col.a);
			}
			ENDCG
		}
	}
}
