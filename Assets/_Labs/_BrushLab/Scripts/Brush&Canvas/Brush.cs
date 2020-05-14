using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Brush", menuName = "BrushLab/Brush")]
public class Brush : ScriptableObject
{
    #region Settings
    public Shader brushShader;
    public Texture brushTexture;

    Material brushMat;
    #endregion

    #region Render Target operation
    RenderTexture renderTarget;
    public RenderTexture RenderTarget
    {
        get
        {
            return renderTarget;
        }
        set
        {
            brushMat = new Material(brushShader);
            renderTarget = value;
        }
    }
    #endregion

    #region Public Call Methods
    public void RenderLine(Vector3 start, Vector3 end, float size, float scale)
    {
        if (renderTarget == null)
            return;

        PreRendering();

        DrawQuadLine(start, end, size, scale);

        PostRendering();
    }

    public void RenderQuad(Vector3 center, float size, float scale)
    {
        if (renderTarget == null)
            return;

        PreRendering();

        DrawQuad(center, size, scale);

        PostRendering();
    }
    #endregion

    #region Internal Draw Methods
    /// <summary>
    /// Jobs that need to be done before GL drawing
    /// </summary>
    void PreRendering()
    {
        //将RenderTarget设为当前目标渲染缓冲，可以把它假想为一个屏幕
        Graphics.SetRenderTarget(renderTarget);

        //保存当前的变换矩阵（保护性操作，在这里意义不大，但是习惯要这么写）
        GL.PushMatrix();
        //载入正交矩阵，用于将后面推入的顶点变换到屏幕空间
        GL.LoadOrtho();

        //设定渲染材质的主贴图
        brushMat.SetTexture("_MainTex", brushTexture);
        //将该材质的第一个pass设定为渲染pass
        brushMat.SetPass(0);
    }

    /// <summary>
    /// Use GL to draw a Quad sequence line
    /// </summary>
    /// <param name="start"></param>
    /// <param name="end"></param>
    /// <param name="size"></param>
    /// <param name="scale"></param>
    void DrawQuadLine(Vector3 start, Vector3 end, float size, float scale)
    {
        DrawQuad(start, size, scale);
        DrawQuad(end, size, scale);
        DrawCenterPointsQuad(start, end, size, scale);
    }

    /// <summary>
    /// Using Divide Algorithm to draw all interploing points of a line 
    /// </summary>
    /// <param name="start"></param>
    /// <param name="end"></param>
    /// <param name="size"></param>
    /// <param name="scale"></param>
    void DrawCenterPointsQuad(Vector3 start, Vector3 end, float size, float scale)
    {
        Vector3 diff = end - start;
        float dis = diff.magnitude;

        if (dis < size * scale * 0.2f)
            return;

        Vector3 middle = (start + end) / 2f;
        DrawQuad(middle, size, scale);
        DrawCenterPointsQuad(start, middle, size, scale);
        DrawCenterPointsQuad(middle, end, size, scale);
    }

    void DrawQuad(Vector3 center, float size, float scale)
    {
        Rect rect = new Rect();
        rect.x = center.x;
        rect.y = center.y;
        rect.width = rect.height = size;

        DrawQuad(rect, scale);
    }

    /// <summary>
    /// Use GL to draw a quad
    /// </summary>
    /// <param name="destRect"></param>
    /// <param name="scale"></param>
    void DrawQuad(Rect destRect, float scale)
    {
        float left = destRect.xMin - destRect.width * scale / 2.0f;
        float right = destRect.xMin + destRect.width * scale / 2.0f;
        float top = destRect.yMin - destRect.height * scale / 2.0f;
        float bottom = destRect.yMin + destRect.height * scale / 2.0f;

        //开始绘制一个四顶点的方块
        GL.Begin(GL.QUADS);

        //设定四个顶点的uv和世界坐标
        GL.TexCoord2(0.0f, 0.0f); GL.Vertex3(left / this.renderTarget.width, top / this.renderTarget.height, 0);
        GL.TexCoord2(1.0f, 0.0f); GL.Vertex3(right / this.renderTarget.width, top / this.renderTarget.height, 0);
        GL.TexCoord2(1.0f, 1.0f); GL.Vertex3(right / this.renderTarget.width, bottom / this.renderTarget.height, 0);
        GL.TexCoord2(0.0f, 1.0f); GL.Vertex3(left / this.renderTarget.width, bottom / this.renderTarget.height, 0);
        //结束绘制，会自动将上面四个顶点封成一个四边形
        GL.End();
    }

    /// <summary>
    /// Jobs that need to be done after GL drawing
    /// </summary>
    void PostRendering()
    {
        //对应PopMatrix，恢复变换矩阵
        GL.PopMatrix();
    }
    #endregion
}
