using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(RawImage))]
public class BrushRawImage : MonoBehaviour
{
    public Brush brush;
    public Color clearColor;
    [Range(0, 10)]
    public float scale;
    RawImage m_Image;
    PaintingCanvas paintingCanvas;
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(StartRoutine());
    }


    IEnumerator StartRoutine()
    {
        //Create a painting canvas to provide RenderTexture, set color to white
        paintingCanvas = new PaintingCanvas(clearColor);
        m_Image = GetComponent<RawImage>();

        //Assign paintingCanvas to RawImage Component 
        m_Image.texture = paintingCanvas.RenderTarget;
        //Set brush
        brush.RenderTarget = paintingCanvas.RenderTarget;

        Vector3? lastInputPosition = null;
        while (true)
        {
            if (Input.GetMouseButton(0))
            {
                Vector3 mousePosition = Input.mousePosition;
                if (lastInputPosition == null)
                    brush.RenderQuad(mousePosition, 20, scale);
                else
                {
                    brush.RenderLine(lastInputPosition.Value, mousePosition, 20, scale);
                }
                lastInputPosition = mousePosition;
            }
            else
            {
                lastInputPosition = null;
            }
            yield return null;
        }
    }
}
