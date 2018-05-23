using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : EffectBase {

	//通过Range控制可以输入的参数的范围  
    [Range(1, 5)]  
    public int scaleSize = 1;//放缩   
	[Range(0.2f, 3.0f)]  
    public float blurSpread = 1.0f;//放缩   
	[Range(0.2f, 3.0f)]  
    public int iterations = 4;//迭代次数   
	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		//仅仅当有材质的时候才进行后处理，如果_Material为空，不进行后处理  
        if (_Material)  
        {  
			int rtW = src.width / scaleSize;
			int rtH = src.height / scaleSize;
            //通过Material.SetXXX（"name",value）可以设置shader中的参数值  
             
			RenderTexture buffer = RenderTexture.GetTemporary(rtW,rtH,0);
			buffer.filterMode = FilterMode.Bilinear;
			Graphics.Blit(src,buffer);
            //使用Material处理Texture，dest不一定是屏幕，后处理效果可以叠加的！
			for(int i = 0;i<iterations;i++){
				_Material.SetFloat("_BlurSize",0.5f + blurSpread * i); 
				RenderTexture buffer1 = RenderTexture.GetTemporary(rtW,rtH,0);
			
            	Graphics.Blit(buffer, buffer1, _Material, 0);  
				RenderTexture.ReleaseTemporary(buffer);
				buffer = buffer1;
				buffer1 = RenderTexture.GetTemporary(rtW,rtH,0);
		
				Graphics.Blit(buffer, buffer1, _Material, 1); 
				RenderTexture.ReleaseTemporary(buffer);
				buffer = buffer1;
			}  
			Graphics.Blit(buffer,dest);
			RenderTexture.ReleaseTemporary(buffer);
        }  
        else  
        {  
            //直接绘制  
            Graphics.Blit(src, dest);  
        }  
	}
}
