using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Level : MonoBehaviour
{
    // Start is called before the first frame update;
    private Text _levelText;
    void Start()
    {
        _levelText = GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        _levelText.text = GrabPickups.Pickup.ToString();
    }
}
