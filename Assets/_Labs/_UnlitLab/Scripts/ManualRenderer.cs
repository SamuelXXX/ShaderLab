using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ManualRenderer : MonoBehaviour
{
    public Camera m_Camera;
    public Cubemap cubemap;
    #region Unity Life Cycle
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnWillRenderObject()
    {

    }

    private void OnPreCull()
    {

    }

    private void OnPreRender()
    {

    }

    private void OnRenderObject()
    {

    }

    private void OnPostRender()
    {
        

    }
    #endregion

    [ContextMenu("To Cubemap")]
    void RenderToCubemap()
    {
        cubemap = new Cubemap(1024, TextureFormat.ARGB32, true);
        m_Camera.RenderToCubemap(cubemap);
    }


}