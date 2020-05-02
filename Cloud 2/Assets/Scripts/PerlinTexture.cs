using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class PerlinTexture : MonoBehaviour
{
    public PatternType pattern;
    public NoiseMethodType type;

    [Range(2, 512)]
    public int resolution = 256;
    private Texture2D texture;
    public float frequency = 1f;

    [Range(1, 8)]
    public int octaves = 1;

    [Range(1f, 4f)]
    public float lacunarity = 2f;

    [Range(0f, 1f)]
    public float persistence = 0.5f;

    [Range(1, 3)]
    public int dimensions = 3;


    private void Update() {
        if(transform.hasChanged)
        {
            transform.hasChanged = false;
            FillTexture();
        }
    }

    [ExecuteInEditMode]
    private void OnEnable() {
        texture = new Texture2D(resolution, resolution, TextureFormat.RGB24, true);
        texture.name = "Perlin Texture";
        texture.wrapMode = TextureWrapMode.Repeat;
        texture.filterMode = FilterMode.Trilinear;
        texture.anisoLevel = 9;
        //GetComponent<MeshRenderer>().material.mainTexture = texture;    
        GetComponent<CloudShape>().cloudMaterial.SetTexture("_CloudTexture", texture);

    }
    
    public void FillTexture()
    {
        if(texture.width != resolution)
        {
            texture.Resize(resolution, resolution);
        }

        Vector3 point00 = (new Vector3 (-0.5f,-0.5f));
        Vector3 point10 = (new Vector3 ( 0.5f,-0.5f));
        Vector3 point01 = (new Vector3 (-0.5f, 0.5f));
        Vector3 point11 = (new Vector3 ( 0.5f, 0.5f));

        NoiseMethod method = Noise.noiseMethods[(int)type][dimensions - 1];
        float stepSize = 1f / resolution;
        
        if(pattern == PatternType.Default)
            DefaultTexture(point00, point10, point01, point11, stepSize, method);
        if(pattern == PatternType.Marble)
            MarbleTexture(point00, point10, point01, point11, stepSize, method);
        
        texture.Apply();
    }

    public void DefaultTexture(Vector3 point00, Vector3 point10, Vector3 point01,
        Vector3 point11, float stepSize, NoiseMethod method)
    {
        for(int y = 0; y < resolution; y++)
        {
            Vector3 point0 = Vector3.Lerp(point00, point01, (y + 0.5f) * stepSize);
            Vector3 point1 = Vector3.Lerp(point10, point11, (y + 0.5f) * stepSize);
            for(int x = 0; x < resolution; x++)
            {
                Vector3 point = Vector3.Lerp(point0, point1, (x + 0.5f) * stepSize);
                float sample = Noise.Sum(method, point, frequency, octaves, lacunarity, persistence);
                
                if(type == NoiseMethodType.Perlin)
                {
                    sample = sample * 0.5f + 0.5f;
                }
                
                texture.SetPixel(x, y, Color.white * (sample * 2f)); 
            }
        }
    }
    
    public void MarbleTexture(Vector3 point00, Vector3 point10, Vector3 point01,
        Vector3 point11, float stepSize, NoiseMethod method)
    {
        for(int y = 0; y < resolution; y++)
        {
            Vector3 point0 = Vector3.Lerp(point00, point01, (y + 0.5f) * stepSize);
            Vector3 point1 = Vector3.Lerp(point10, point11, (y + 0.5f) * stepSize);
            for(int x = 0; x < resolution; x++)
            {
                Vector3 point = Vector3.Lerp(point0, point1, (x + 0.5f) * stepSize);
                Vector2 pNoise = new Vector2(y, x) * frequency;
                // This value could and should probably be a public float variable to be changed in editor
                float sample = 0f; 
                sample = Noise.Sum(method, point, frequency, octaves, lacunarity, persistence);
                
                if(type == NoiseMethodType.Perlin)
                {
                    sample *= 0.5f + 0.5f;
                }

                texture.SetPixel(x, y, Color.white * (Mathf.Sin((x + sample * 100) * 2 * Mathf.PI / 200f) +1) / 2f);
            }
        }
    }
}
