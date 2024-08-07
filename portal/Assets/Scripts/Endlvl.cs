using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Endlvl : MonoBehaviour
{
    public GameObject UiObject;

    // Start is called before the first frame update
    void Start()
    {
        UiObject.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            UiObject.SetActive(true);
        }
	}
}
