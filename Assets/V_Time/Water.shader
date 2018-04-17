Shader "Unlit/Water"
{
		//物体需要横向移动 需要改变顶点
	//问题需要纵向移动需要改变UV
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color Tint",Color) = (1,1,1,1)
		_Magnitude("Distortion Magnitude",Float) = 0.1//水流幅度
		_Frequency("Distortion Fraquency",Float) = 0.5//水流频率
		_InvWaveLength("Diatortion Inverse Wave Length",Float) = 5
		_Speed("Speed",Float) = 0.5

	}
	SubShader
	{
		Tags { 
			"RenderType"="Transparent"
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"DisableBatching" = "True"
			 }
		LOD 100

		Pass
		{
			Tags{
				"LightMode" = "ForwardBase"
			}
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull off
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
			Float _Frequency;
			Float _InvWaveLength;
			Float _Magnitude;
			Float _Speed;
			float4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				float4 offset;
				offset.xyzw = float4(0,0,0,0);
				offset.x = sin(_Time.y*_Frequency+v.vertex.x*_InvWaveLength
				+v.vertex.z*_InvWaveLength)*_Magnitude;
				o.vertex = UnityObjectToClipPos(v.vertex+offset);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv+=float2(0.0,_Time.y*_Speed);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col*_Color;
			}
			ENDCG
		}
	}
}
