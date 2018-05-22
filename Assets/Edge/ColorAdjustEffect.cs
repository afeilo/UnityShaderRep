using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorAdjustEffect : MonoBehaviour {

	public Shader shader = null;  
    private Material _material = null; 

	//通过Range控制可以输入的参数的范围  
    [Range(0.0f, 3.0f)]  
    public float brightness = 1.0f;//亮度  
    [Range(0.0f, 1.0f)]  
    public float contrast = 1.0f;  //对比度  
    [Range(0.0f, 1.0f)]  
    public float saturation = 1.0f;//饱和度   
    public Material _Material  
    {  
        get  
        {  
            if (_material == null)  
                _material = GenerateMaterial(shader);  
            return _material;  
        }  
    } 

	//根据shader创建用于屏幕特效的材质  
    protected Material GenerateMaterial(Shader shader)  
    {  
        if (shader == null)  
            return null;  
        //需要判断shader是否支持  
        if (shader.isSupported == false)  
            return null;  
        Material material = new Material(shader);  
        material.hideFlags = HideFlags.DontSave;  
        if (material)  
            return material;  
        return null;  
    }  
	
	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		//仅仅当有材质的时候才进行后处理，如果_Material为空，不进行后处理  
        if (_Material)  
        {  
            //通过Material.SetXXX（"name",value）可以设置shader中的参数值  
            _Material.SetFloat("_Brightness", brightness);  
            _Material.SetFloat("_Saturation", saturation);  
            _Material.SetFloat("_Contrast", contrast);  
            //使用Material处理Texture，dest不一定是屏幕，后处理效果可以叠加的！  
            Graphics.Blit(src, dest, _Material);  
        }  
        else  
        {  
            //直接绘制  
            Graphics.Blit(src, dest);  
        }  
	}
}
