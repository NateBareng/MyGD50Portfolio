using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Death : MonoBehaviour
{
    private CharacterController _characterController;
    private float _heightThreshold;
    // Start is called before the first frame update
    void Start()
    {
        _characterController = GetComponent<CharacterController>();
        _heightThreshold = GameObject.Find("FloorParent").transform.position.y;
    }

    // Update is called once per frame
    void Update()
    {
        if (_characterController.transform.position.y < _heightThreshold)
        {
            SceneManager.LoadScene("GameOver");
        }
    }
}
