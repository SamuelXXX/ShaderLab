using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintingCanvas
{
    public RenderTexture RenderTarget
    {
        get;
        private set;
    }

    public PaintingCanvas(Texture background)
    {
        RenderTarget = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
        Clear(background);

    }

    public PaintingCanvas()
    {
        RenderTarget = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
    }

    public PaintingCanvas(Color color)
    {
        RenderTarget = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
        Clear(color);
    }

    public void Clear(Color color)
    {
        Graphics.SetRenderTarget(RenderTarget);
        GL.PushMatrix();
        GL.Clear(true, true, color);
        GL.PopMatrix();
    }

    public void Clear(Texture texture)
    {
        Graphics.SetRenderTarget(RenderTarget);
        Graphics.DrawTexture(new Rect(0, 0, 1, 1), texture);
    }
}
