Shader "Custom/ZTest2" {  
    Properties {  
        _MainTex ("Base (RGB)", 2D) = "white" {}  
    }  
    SubShader {  
        Tags { "RenderType"="Opaque" }  
        LOD 200  
/////////////////////////////////////////测试区  
        Tags{ "Queue" = "Geometry" }  
        ZWrite Off  
        // ZTest Off  
/////////////////////////////////////////测试区  
        CGPROGRAM  
        #pragma surface surf Lambert  
  
        sampler2D _MainTex;  
  
        struct Input {  
            float2 uv_MainTex;  
        };  
  
        void surf (Input IN, inout SurfaceOutput o) {  
            half4 c = tex2D (_MainTex, IN.uv_MainTex);  
            o.Albedo = c.rgb;  
            o.Alpha = c.a;  
        }  
        ENDCG  
    }   
    FallBack "Diffuse"  
}  